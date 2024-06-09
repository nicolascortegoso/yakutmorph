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

    number = re.compile(r'\b[+-]?\d+(\.\d+)?\b')
    email = re.compile(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b')
    url = re.compile(
        r"""
        (https?://)?               # Optional protocol (http:// or https://)
        ([a-zA-Z0-9.-]+)           # Domain (may include subdomains)
        (\.[a-zA-Z]{2,})           # Top-level domain (TLD)
        (/[a-zA-Z0-9_/-]*)?        # Optional path
        """,
        re.VERBOSE
    )
    phone = re.compile(
        r"""
        ^                    # Start of string
        (?:\+\d{1,2}\s?)?    # Optional international code with or without space
        (?:                  # Optional group for area code
            \(\d{1,4}\)      # Area code in parentheses
            |                # OR
            \d{1,4}          # Area code without parentheses
        )?                   # Area code is optional
        [-.\s]?              # Optional separator (dash, dot, or space)
        \d{1,}               # Phone number digits (at least one digit)
        -?                   # Optional dash
        \d{1,}               # More phone number digits (at least one digit)
        -?                   # Optional dash
        \d{1,}               # More phone number digits (at least one digit)
        $                    # End of string
        """,
        re.VERBOSE
    )
    date = re.compile(
        r"""
        (
            (\d{4}[-/]\d{1,2}[-/]\d{1,2})         # YYYY-MM-DD or YYYY/MM/DD
            |                                     # OR
            (\d{1,2}[-/]\d{1,2}[-/]\d{4})         # MM-DD-YYYY or MM/DD/YYYY
            |                                     # OR
            (\d{1,2}[-/]\d{1,2}[-/]\d{2})         # MM-DD-YY or MM/DD/YY
            |                                     # OR
            (\d{4}[-/]\d{1,2}[-/]\d{1,2}          # YYYY-MM-DD
             \s\d{1,2}:\d{1,2}:\d{1,2})           # HH:MM:SS
            |                                     # OR
            (\d{1,2}[-/]\d{1,2}[-/]\d{4}          # MM-DD-YYYY
             \s\d{1,2}:\d{1,2}:\d{1,2})           # HH:MM:SS
            |                                     # OR
            (\d{1,2}/\d{1,2}/\d{4})               # MM/DD/YYYY
        )
        """,
        re.VERBOSE
    )
    roman = re.compile(
        r"""
        ^                # Start of string
        M{0,3}           # Thousands - 0 to 3 'M's
        (CM|CD|D?C{0,3}) # Hundreds - 900 (CM), 400 (CD), 0-300 (0 to 3 'C's), or 500-800 (D, followed by 0 to 3 'C's)
        (XC|XL|L?X{0,3}) # Tens - 90 (XC), 40 (XL), 0-30 (0 to 3 'X's), or 50-80 (L, followed by 0 to 3 'X's)
        (IX|IV|V?I{0,3}) # Units - 9 (IX), 4 (IV), 0-3 (0 to 3 'I's), or 5-8 (V, followed by 0 to 3 'I's)
        $                # End of string
        """,
        re.VERBOSE
    )

    def __init__(self):
        """
        Initialize the `YakutTokenizer` with regular expressions and tokenization rules.

        This constructor sets up a scanner with rules to identify various token types.
        """

        self.scanner = re.Scanner([
            (self.number.pattern, lambda scanner, token: (token, self.token_type.NUMBER)),
            (self.url.pattern, lambda scanner, token: (token, self.token_type.URI)),
            (self.email.pattern, lambda scanner, token: (token, self.token_type.EMAIL)),
            (self.phone.pattern, lambda scanner, token: (token, self.token_type.PHONE)),
            (self.date.pattern, lambda scanner, token: (token, self.token_type.DATE)),
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
