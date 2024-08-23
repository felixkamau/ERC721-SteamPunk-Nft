const hre = require("hardhat");
const { ContractFunction } = require("hardhat/internal/hardhat-network/stack-traces/model");

// Deployed Addresses
// SteamPunk#SteamPunk - 0x5FbDB2315678afecb367f032d93F642f64180aa3

async function main(){
    const [owner, addr1] = await hre.ethers.getSigners();

    const MintContract = await hre.ethers.getContractFactory("SteamPunk");
    
    const mintContract = await MintContract.attach('0x5FbDB2315678afecb367f032d93F642f64180aa3');
    // console.log(mintContract);

    // mint to addr1
    const mintPrice = await mintContract.mintPrice();
    console.log(`Minting price: ${mintPrice}`);

    const maxSupply  = await mintContract.maxSupply();
    console.log(`MaxSupply: ${maxSupply}`);

    await mintContract.connect(addr1).safeMint(addr1.address, {value: mintPrice});
    console.log(addr1.address);

    console.log(`Minted token to ${addr1.address}`);

    const totalSupply = await mintContract.totalSupply();
    console.log(`Total Supply: ${totalSupply}`);

    const ownerOf = await mintContract.ownerOf(1);
    console.log(`Owner of id: ${ownerOf}`)


    // Get owner of


}

// npx hardhat run scripts/mint.js --network localhost
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});