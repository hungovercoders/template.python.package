"""Greeting functions for the Hungover Coders template package.

This module provides simple greeting and farewell functions with CLI
interfaces.
"""

import argparse
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# TODO: Consider using typer library instead of argparse for better CLI


def hello(name: str) -> str:
    """Greet the user by name.

    Args:
        name: The name of the person to greet.

    Returns:
        The greeting message.

    Example:
        >>> hello("Alice")
        'Hungovercoders say hello to Alice!'
    """
    message = f"Hungovercoders say hello to {name}!"
    logger.info(f"Generated greeting for {name}")
    return message


def hello_cli() -> None:
    """CLI entry point for greeting.

    Parses command line arguments and calls the hello function.
    """
    parser = argparse.ArgumentParser(
        description="Generate a greeting from Hungover Coders",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--name", type=str, default="World", help="Name of the person to greet"
    )
    args = parser.parse_args()

    message = hello(args.name)
    print(message)


def goodbye(name: str) -> str:
    """Farewell the user by name.

    Args:
        name: The name of the person to bid farewell.

    Returns:
        The farewell message.

    Example:
        >>> goodbye("Bob")
        'Hungovercoders say goodbye to Bob!'
    """
    message = f"Hungovercoders say goodbye to {name}!"
    logger.info(f"Generated farewell for {name}")
    return message


def goodbye_cli() -> None:
    """CLI entry point for farewell.

    Parses command line arguments and calls the goodbye function.
    """
    parser = argparse.ArgumentParser(
        description="Generate a farewell from Hungover Coders",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--name", type=str, default="World", help="Name of the person to bid farewell"
    )
    args = parser.parse_args()

    message = goodbye(args.name)
    print(message)
