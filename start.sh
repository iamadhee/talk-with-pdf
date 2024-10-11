#!/bin/bash

# Start Ollama in the background
ollama serve &

# Wait until Ollama is ready (this can be improved with a more sophisticated check)
sleep 10

# Pull the required model
ollama pull llama3.2:3b

# Start the Python app
python app.py
