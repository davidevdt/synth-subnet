#!/bin/bash

# Check if the number of miners is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_miners>"
  exit 1
fi

NUM_MINERS=$1

# Loop over the number of miners
for ((i=1; i<=NUM_MINERS; i++)); do
  # Set the miner name and port based on the iteration index
  if [ $i -eq 1 ]; then
    MINER_NAME="miner"
    PORT=8092
    SIGMA=0.01
  else
    MINER_NAME="miner$i"
    PORT=$((8092 + i))
    SIGMA=$(echo "0.01 * $i" | bc)
  fi

  # Create a configuration file for the miner
  CONFIG_FILE="miner_$i.config.js"
  cat > $CONFIG_FILE <<EOL
module.exports = {
  apps: [
    {
      name: '$MINER_NAME',
      script: 'python3',
      args: './neurons/miner.py --netuid 247 --logging.debug --logging.trace --subtensor.network test --wallet.name $MINER_NAME --wallet.hotkey default --axon.port $PORT --sigma $SIGMA'
    },
  ],
};
EOL

  # Start the miner using PM2
  pm2 start $CONFIG_FILE

done

# Display running miners
pm2 list