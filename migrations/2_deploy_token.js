const token = artifacts.require('./ERC721Token.sol')

module.exports = (deployer) => {
    deployer.deploy(token);
}
