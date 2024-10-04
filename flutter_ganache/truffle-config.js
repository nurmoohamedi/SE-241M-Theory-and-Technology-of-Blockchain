module.exports = {
  networks: {
    networks: {
      development: {
        host: "http://127.0.0.1",
        port: 7545,
        network_id: "*",
      },
      privateNode: {
        host: '127.0.0.1',
        port: 8501,               
        network_id: '*'
      },
      ganache: {
        host: "127.0.0.1",
        port: 7545,
        network_id: "*"
      }
    },
    contracts_directory: './contracts/',
  compilers: {
    solc: {
      version: "0.8.0",
      optimizer: {
        enabled: true,
        runs: 200
      }     
    }
  },
  },
  db: {
    enabled: false
  }
};
