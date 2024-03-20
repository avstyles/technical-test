# Technical Test

This repository contains the technical test of creating an iOS app using an API. I selected the dictionary API at https://dictionaryapi.dev this allows you to submit a word and receive a list of definitions back. This is a simple app with a basic design, the purpose is to demonstrate my development style and principles. I have used a MVVM architecture with dependancies injected for testablity. 

## Testing
- Unit tests - cover the view model and networking components 
- UI tests - test the view and interactions, mock JSON is injected at the networking layer

## Improvements
- Improve error handling for more specific scenarios
- Implement a coordinator pattern for navigation
- Add further features e.g. phonetic audio, word origin
