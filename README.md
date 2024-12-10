# WPSD Status CLI

The **WPSD Status CLI** is a Bash script that provides a dynamic, live update interface for monitoring WPSD status information. It fetches data from a backend web service and displays it in the terminal with a clean and interactive interface.


## Features

- **Live Updates**: Continuously fetches and displays WPSD status information at regular intervals.
- **Dynamic ASCII Art**: Displays call signs in large text using `figlet`.
- **Customizable Refresh**: Set the refresh interval for live updates.
- **Interactive Exit**: Press `q` at any time to gracefully exit the script.



## Requirements

### Tools:
- `bash` (script interpreter) - WPSD already has this
- `curl` (for fetching data) - WPSD already has this
- `figlet` (for large ASCII text rendering) - don't recall if this was installed by me or it was already present

### Install Dependencies:

1. Install figlet:
  ```bash
  sudo apt install figlet   
  ```

## Usage

### Clone the Repository

Clone the repository to your local machine:
  ```bash
  git clone https://github.com/chevybowtie/wpsd-status-cli.git
  cd wpsd-status-cli
  ```

### Run the Script
Make the script executable:

```bash
chmod +x live-figlet.sh
```

Run the script:

```bash
./live-figlet.sh
```


## Configuration

### Update Interval

To change the interval for live updates, edit the UPDATE_INTERVAL variable in the script:

```bash
UPDATE_INTERVAL=1.5  # Time in seconds
```

## Contribution

Contributions are welcome! Feel free to submit issues or pull requests.

### TODOs:

* Add support for multiple hot spots
* Enhance error handling for connection issues.
* Add unit tests for script functions.

For questions or feedback, please open an issue on the GitHub repository. 😊

