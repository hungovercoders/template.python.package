#!/usr/bin/env python3
"""Simple test watcher script that runs pytest when files change."""

import subprocess
import sys
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class TestHandler(FileSystemEventHandler):
    """Handler that runs tests when Python files change."""
    
    def __init__(self):
        self.last_run = 0
        self.debounce_seconds = 1  # Avoid running tests too frequently
        
    def on_modified(self, event):
        """Run tests when a Python file is modified."""
        if event.is_directory:
            return
            
        # Only watch .py files
        if not event.src_path.endswith('.py'):
            return
            
        # Debounce rapid file changes
        current_time = time.time()
        if current_time - self.last_run < self.debounce_seconds:
            return
            
        self.last_run = current_time
        self.run_tests()
        
    def run_tests(self):
        """Run the test suite."""
        print("\n" + "="*80)
        print("🔄 Running tests...")
        print("="*80)
        
        try:
            result = subprocess.run([
                sys.executable, "-m", "pytest",
                "-v", "--tb=short", "--no-header"
            ], cwd=Path(__file__).parent.parent)

            if result.returncode == 0:
                print("\n✅ All tests passed!")
            else:
                print("\n❌ Some tests failed!")

        except KeyboardInterrupt:
            print("\n⏹️  Test run interrupted")
            raise
        except Exception as e:
            print(f"\n💥 Error running tests: {e}")

        print("\n👀 Watching for changes... (Press Ctrl+C to stop)")


def main():
    """Main function to set up file watching."""
    print("🧪 Starting test watcher...")
    print("👀 Watching for changes in src/ and tests/ directories")
    print("Press Ctrl+C to stop\n")
    
    # Run tests once at startup
    handler = TestHandler()
    handler.run_tests()
    
    # Set up file watcher
    observer = Observer()
    
    # Watch source and test directories
    src_dir = Path(__file__).parent.parent / "src"
    tests_dir = Path(__file__).parent.parent / "tests"
    
    if src_dir.exists():
        observer.schedule(handler, str(src_dir), recursive=True)
        print(f"📂 Watching: {src_dir}")
        
    if tests_dir.exists():
        observer.schedule(handler, str(tests_dir), recursive=True)
        print(f"📂 Watching: {tests_dir}")
    
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Stopping test watcher...")
        observer.stop()
    
    observer.join()
    print("👋 Test watcher stopped!")


if __name__ == "__main__":
    main()
