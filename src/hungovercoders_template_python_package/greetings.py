import argparse

def hello(name: str) -> None:
    """Greet the user by name."""
    print(f"Hungovercoders say hello to {name}!")

def hello_cli() -> None:
    """CLI entry point for greeting."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", type=str, default="World")
    args = parser.parse_args()
    hello(args.name)