CXX = g++
CXXFLAGS = -g -Wall
SRC = $(wildcard *.cpp)
OBJ = $(SRC:.cpp=.o)

ifeq ($(OS),Windows_NT)
    TARGET = main.exe
    RM = del /Q
else
    TARGET = main.out
    RM = rm -f
endif

build: $(TARGET) ## build app

run: build ## build and run app
	@./$(TARGET)

$(TARGET): $(OBJ) ## cbuild app
	@$(CXX) $(CXXFLAGS) $(OBJ) -o $(TARGET)

%.o: %.cpp ## compile .cpp files
	@$(CXX) $(CXXFLAGS) -c $< -o $@

clean: ## remove intermediate build files and compiled application
	@$(RM) $(TARGET) $(OBJ)


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean build
