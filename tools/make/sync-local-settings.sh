#!/bin/sh

# Syncs local.settings.php with an Azure Key Vault secret.
#
# Usage: sync-local-settings.sh <download|upload> <vault> <secret> <file> [days]
#
# Asks before overwriting a file or a secret with different content. The
# content is never printed. Uploaded secrets expire after the given number of
# days (90 by default), because the Key Vault policy requires an expiry date.

set -eu

if [ $# -lt 4 ] || [ $# -gt 5 ]; then
  echo "Usage: $0 <download|upload> <vault> <secret> <file> [days]" >&2
  exit 1
fi

direction=$1
vault=$2
secret=$3
file=$4
days=${5:-90}

confirm() {
  printf '%s [y/N] ' "$1"
  read -r answer
  case $answer in
    [yY]*) return 0 ;;
    *) return 1 ;;
  esac
}

download() {
  if ! value=$(az keyvault secret show --vault-name "$vault" --name "$secret" --query value -o tsv); then
    echo "Could not read secret '$secret' from Key Vault '$vault'." >&2
    exit 1
  fi

  if [ -z "$value" ]; then
    echo "Secret '$secret' is empty." >&2
    exit 1
  fi

  if [ -f "$file" ]; then
    if [ "$(cat "$file")" = "$value" ]; then
      echo "$file is up to date."
      exit 0
    fi
    if ! confirm "$file has local changes. Overwrite it?"; then
      echo "Kept $file as it is."
      exit 0
    fi
  fi

  umask 077
  printf '%s\n' "$value" > "$file"
  echo "Saved $file."
}

upload() {
  if [ ! -s "$file" ]; then
    echo "$file doesn't exist or is empty." >&2
    exit 1
  fi

  # Key Vault secrets can be at most 25 KB.
  if [ "$(wc -c < "$file")" -gt 25600 ]; then
    echo "$file is larger than the 25 KB Key Vault allows." >&2
    exit 1
  fi

  error_file=$(mktemp)
  trap 'rm -f "$error_file"' EXIT
  if value=$(az keyvault secret show --vault-name "$vault" --name "$secret" --query value -o tsv 2> "$error_file"); then
    if [ "$(cat "$file")" = "$value" ]; then
      expires=$(az keyvault secret show --vault-name "$vault" --name "$secret" --query attributes.expires -o tsv)
      question="Secret '$secret' is up to date and expires on $expires. Renew it for $days days?"
    else
      question="Replace secret '$secret' in Key Vault '$vault' for everyone with $file?"
    fi
  elif grep -q SecretNotFound "$error_file"; then
    question="Create secret '$secret' in Key Vault '$vault' from $file?"
  else
    # For example, a disabled secret can't be read, but it can be replaced.
    cat "$error_file" >&2
    question="Could not read secret '$secret'. Replace it with $file anyway?"
  fi

  if ! confirm "$question"; then
    echo "Kept secret '$secret' as it is."
    exit 0
  fi

  expires=$(date -u -d "+$days days" +%Y-%m-%dT%H:%M:%SZ)
  # The output contains the value, so don't print it.
  az keyvault secret set --vault-name "$vault" --name "$secret" --file "$file" \
    --content-type 'text/x-php' --expires "$expires" > /dev/null
  echo "Saved secret '$secret'. It expires on $expires."
}

case $direction in
  download) download ;;
  upload) upload ;;
  *) echo "Unknown direction '$direction', use download or upload." >&2; exit 1 ;;
esac
