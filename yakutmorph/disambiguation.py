import pickle
from typing import List, Tuple, Dict

import torch
import torch.nn.functional as F
from torch import nn

from .interfaces import DisambiguationModel
from .utils import get_file_path


class GRUModel(nn.Module):
    """
    A GRU-based neural network model for sequence prediction tasks.
    """
    def __init__(self, vocab_size: int, embed_size: int, hidden_size: int, num_layers: int, padding_idx: int):
        """
        Initializes the GRUModel with the given parameters.

        :param vocab_size: The size of the vocabulary.
        :param embed_size: The size of the embedding vectors.
        :param hidden_size: The number of features in the hidden state of the GRU.
        :param num_layers: The number of recurrent layers in the GRU.
        :param padding_idx:  The index of the padding token in the embeddings.
        """
        super(GRUModel, self).__init__()
        self.hidden_dim = hidden_size
        self.num_layers = num_layers
        self.embedding = nn.Embedding(vocab_size, embed_size, padding_idx=padding_idx)
        self.gru = nn.GRU(embed_size, hidden_size, num_layers, bidirectional=True, batch_first=True)
        self.fc = nn.Linear(hidden_size * 2, vocab_size)

    def forward(self, x: torch.Tensor, hidden: torch.Tensor) -> Tuple[torch.Tensor, torch.Tensor]:
        """
        Defines the forward pass of the model.

        :param x: Input tensor containing token indices.
        :param hidden: Initial hidden state for the GRU.
        :return: A tuple containing a tensor with the predicted token scores and 
            and another tensor with the hidden states from the GRU.
        """
        x = self.embedding(x)
        out, hidden = self.gru(x, hidden)
        out = self.fc(out)
        return out, hidden

    def init_hidden(self, batch_size):
        return torch.zeros(self.num_layers * 2, batch_size, self.hidden_dim)


class YakutModel(DisambiguationModel, GRUModel):
    """
    A model for disambiguating morphological analyses using a GRU-based neural network.
    """
    def __init__(self):
        vocab_size, self.stoi, self.itos = self.load_mappings('data/vocabulary.pkl')

        embed_size = 32
        self.hidden_size = 32
        self.num_layers = 1
        self.padding_idx = self.stoi['<PAD>']
        self.unknown_idx = self.stoi['^UNK']

        super(YakutModel, self).__init__(vocab_size, embed_size, self.hidden_size, self.num_layers, self.padding_idx)
        self.load_state_dict(torch.load(get_file_path('data/gru_weights.pth')))
        self.eval()

    def load_mappings(self, filename: str) -> Tuple[int, Dict, Dict]:
        """
        Loads vocabulary mappings from a file.

        :param filename: The path to the file containing the vocabulary mappings.
        :return: A tuple containing the size of the vocabulary, a dictionary mapping
            strings to indices, and a dictionary mapping indices to strings.
        """
        with open(get_file_path(filename), 'rb') as f:
            mappings = pickle.load(f)
        return len(mappings['stoi']), mappings['stoi'], mappings['itos']

    def beam_search(self, dag: List[List[str]], beam_width: int = 5, apply_softmax: bool = True) -> List[int]:
        """
        Performs beam search to find the most probable sequence of morphological analyses.

        :param dag: A directed acyclic graph representing possible analyses.
        :param beam_width: The width of the beam search. Defaults to 5.
        :param apply_softmax: Apply softmax to the model's output. Defaults to True.
        :return: A list with the indices with the most probable analysis.
        """
        start_token = dag.pop(0)[0]
        start_token_idx = self.stoi.get(start_token)

        branches = [
            [(1.0, [start_token_idx], self.init_hidden(1))]
        ]  # Initialize with model's hidden state

        for analyses in dag:
            new_branches = list()
            for score, seq, hidden in branches[-1]:

                input_seq = torch.tensor([seq[-1]], dtype=torch.long).unsqueeze(0)

                with torch.no_grad():
                    output, hidden = self(input_seq, hidden)

                # Convert to probabilities
                next_ig_idxs = [self.stoi.get(analysis, self.stoi['^UNK']) for analysis in analyses]
                logs = output[..., next_ig_idxs]

                if apply_softmax:
                    probabilities = F.softmax(logs, dim=2)

                for i, analysis in enumerate(analyses):
                    updated_seq = seq + [next_ig_idxs[i]]
                    if apply_softmax:
                        updated_score = score * probabilities[0, 0, i].item()
                    else:
                        updated_score = score + logs[0, 0, i].item()

                    new_branch = (updated_score, updated_seq, hidden)
                    if new_branch not in new_branches:
                        new_branches.append(new_branch)

            new_branches = sorted(new_branches, key=lambda tup: tup[0], reverse=True)[:beam_width]

            branches.append(new_branches)

        most_likely_sequence = [self.itos[idx] for idx in branches[-1][0][1]]
        return most_likely_sequence

    def disambiguate(self, dag: List[List[str]]) -> List[int]:
        """
        Disambiguates the morphological analyses in a directed acyclic graph (DAG).

        :param dag: A directed acyclic graph representing possible analyses.
        :return: The indices of the selected analyses in the DAG.
        """
        most_probable_sequence = self.beam_search(dag)
        most_probable_sequence = most_probable_sequence[1:]

        indexes = [0] * len(most_probable_sequence)

        for i, token in enumerate(dag):
            for e, analysis in enumerate(token):
                if analysis == most_probable_sequence[i]:
                    indexes[i] = e
        return indexes[:-1]
