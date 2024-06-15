import re
from types import SimpleNamespace
from typing import List, Tuple

from .interfaces import Tokenizer


class TokenizationException(Exception):
    """Exception class for tokenization errors."""
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)


class YakutTokenizer(Tokenizer):
    """
    A tokenizer for the Yakut language with specialized token types and regular expressions.

    The `YakutTokenizer` class extends the `Tokenizer` protocol and provides
    functionality to tokenize text into various types including titles, uppercase,
    lowercase, URIs, emails, phone numbers, dates, numbers, Roman numerals, and
    various punctuation marks.
    """

    # A dictionary mapping token type names to their string representations.
    token_types = {
        'TITLE': 'title',
        'UPPERCASE': 'uppercase',
        'LOWERCASE': 'lowercase',
        'TITLELAT': 'title_lat',
        'UPPERCASELAT': 'uppercase_lat',
        'LOWERCASELAT': 'lowercase_lat',
        'URI': 'uri',
        'EMAIL': 'email',
        'PHONE': 'phone',
        'DATE': 'date',
        'NUMBER': 'number',
        'ROMAN': 'roman',
        'UNKNOWN': 'unknown',
        'HYPHEN': 'hyphen',
        'COMMA': 'comma',
        'COLON': 'colon',
        'SEMICOLON': 'semicolon',
        'STOP': 'period',
        'QUESTION': 'question',
        'EXCLAMATION': 'exclamation',
        'ELLIPSIS': 'ellipsis',
        'QUOTATION': 'quotation',
        'BRACKET': 'bracket',
        'DASH': 'dash',
        'SYMBOL': 'symbol'
    }

    token_type = SimpleNamespace(**token_types)

    title = re.compile("[А-ЯЁҺҔҤӨҮ][а-яёһҕҥөү]+")
    uppercase = re.compile("[А-ЯЁҺҔҤӨҮ]+")
    lowercase = re.compile("[а-яёһҕҥөү]+")
    title_lat = re.compile("[A-Z][a-z]+")
    uppercase_lat = re.compile("[A-Z]+")
    lowercase_lat = re.compile("[a-z]+")

    phone = re.compile(r'\+?\d{1,4}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}\b')
    date = re.compile(r'\b(?:\d{4}[-/. ](?:0?[1-9]|1[0-2])[-/. ](?:0?[1-9]|[12]\d|3[01])|(?:0?[1-9]|1[0-2])[-/. ](?:0?[1-9]|[12]\d|3[01])[-/. ]\d{4}|(?:0?[1-9]|[12]\d|3[01])[-/. ](?:0?[1-9]|1[0-2])[-/. ]\d{4}|(?:0?[1-9]|1[0-2])[-/. ](?:0?[1-9]|[12]\d|3[01])[-/. ]\d{2}|(?:0?[1-9]|[12]\d|3[01])[-/. ](?:0?[1-9]|1[0-2])[-/. ]\d{2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*[-. ](?:0?[1-9]|[12]\d|3[01])[-, ]\d{4}|(?:0?[1-9]|1[0-2])[-. ](?:0?[1-9]|[12]\d|3[01])[-, ]\d{4})\b')
    number = re.compile(r'\b[+-]?\d+(\.\d+)?\b')
    url = re.compile(r'\b(https?://)?([a-zA-Z0-9.-]+)(\.[a-zA-Z]{2,})(/[a-zA-Z0-9_/-]*)?\b')
    email = re.compile(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b')
    roman = re.compile(r'(?=\b[MCDXLVI]{1,6}\b)M{0,4}(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3})')

    def __init__(self):
        """
        Initialize the `YakutTokenizer` with regular expressions and tokenization rules.

        This constructor sets up a scanner with rules to identify various token types.
        """

        self.scanner = re.Scanner([
            (self.phone.pattern, lambda scanner, token: (token, self.token_type.PHONE)),
            (self.date.pattern, lambda scanner, token: (token, self.token_type.DATE)),
            (self.number.pattern, lambda scanner, token: (token, self.token_type.NUMBER)),
            (self.url.pattern, lambda scanner, token: (token, self.token_type.URI)),
            (self.email.pattern, lambda scanner, token: (token, self.token_type.EMAIL)),
            (self.roman.pattern, lambda scanner, token: (token, self.token_type.ROMAN)),
            (r"[—–]", lambda scanner, token: (token, self.token_type.DASH)),
            (r"-", lambda scanner, token: (token, self.token_type.HYPHEN)),
            (r"[\"'«»`“”‘’]", lambda scanner, token: (token, self.token_type.QUOTATION)),
            (r"[\(\)\[\]{}]", lambda scanner, token: (token, self.token_type.BRACKET)),
            (r"\?+", lambda scanner, token: (token, self.token_type.QUESTION)),
            (r"!+", lambda scanner, token: (token, self.token_type.EXCLAMATION)),
            (r"\.{2,}", lambda scanner, token: (token, self.token_type.ELLIPSIS)),
            (r"\.", lambda scanner, token: (token, self.token_type.STOP)),
            (r",", lambda scanner, token: (token, self.token_type.COMMA)),
            (r":", lambda scanner, token: (token, self.token_type.COLON)),
            (r";", lambda scanner, token: (token, self.token_type.SEMICOLON)),
            (r"[\$%&№@#&\*\+\-]+", lambda scanner, token: (token, self.token_type.SYMBOL)),
            (self.title.pattern, lambda scanner, token: (token, self.token_type.TITLE)),
            (self.uppercase.pattern, lambda scanner, token: (token, self.token_type.UPPERCASE)),
            (self.lowercase.pattern, lambda scanner, token: (token, self.token_type.LOWERCASE)),
            (self.title_lat.pattern, lambda scanner, token: (token, self.token_type.TITLELAT)),
            (self.uppercase_lat.pattern, lambda scanner, token: (token, self.token_type.UPPERCASELAT)),
            (self.lowercase_lat.pattern, lambda scanner, token: (token, self.token_type.LOWERCASELAT)),
            (r"\s+", lambda scanner, token: None),                          # spaces are ignored
            (r".", lambda scanner, token: (token, self.token_type.UNKNOWN))
        ])

    def tokenize(self, input_text: str) -> List[Tuple[str, str]]:
        """
        Tokenize the input text into a list of (token, type) tuples.

        :param input_text: The text to be tokenized.
        :return: A list of tuples where each tuple contains a token and its corresponding type.
        """
        tokens, not_recognized = self.scanner.scan(input_text)
        if not_recognized:
            raise TokenizationException(f'The substring "{not_recognized}" was not tokenized')
        return tokens

    def has_morphology(self) -> List[str]:
        """
        Return a list of token types that have morphological features.

        :return: A list of token types that have morphological features.
        """
        return [
            self.token_type.TITLE, self.token_type.UPPERCASE, self.token_type.LOWERCASE
        ]
