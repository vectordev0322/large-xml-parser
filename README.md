# Large XML Parser with Nokogiri SAX

This project demonstrates how to efficiently parse large XML files using Ruby and the Nokogiri SAX parser. The script processes the XML file incrementally, extracts relevant data, and batches it dynamically to avoid memory overload.

---

## Features

- **Streaming Parsing**: Processes the XML file incrementally using the SAX parser, avoiding memory issues with large files.
- **Dynamic Batching**: Groups parsed data into batches, ensuring each batch stays under a configurable size limit (default: 5MB).
- **Low Memory Usage**: Only the current element and batch data are stored in memory at any given time.
- **Scalable**: Handles files of any size, even terabyte-scale XML files, provided sufficient computational resources.

---

## Prerequisites

- Ruby 2.x or later installed on your system.
- The `nokogiri` gem installed.

To install Nokogiri, run:

```bash
gem install nokogiri