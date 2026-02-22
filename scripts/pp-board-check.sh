#!/bin/bash
# Check PP Product board for Ready items
# Usage: ./scripts/pp-board-check.sh [board_number]

BOARD=${1:-2}  # Default to PP Product (board 2)

GH_TOKEN=$(cat ~/.openclaw/secrets/github-pat-projects.txt) gh api graphql -f query="
query {
  organization(login: \"Roca-Ventures\") {
    projectV2(number: $BOARD) {
      title
      items(first: 100) {
        nodes {
          id
          fieldValueByName(name: \"Status\") {
            ... on ProjectV2ItemFieldSingleSelectValue { name optionId }
          }
          content {
            ... on DraftIssue { title body }
            ... on Issue { title number url }
          }
        }
      }
    }
  }
}" 2>&1
