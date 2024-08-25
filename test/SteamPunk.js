const { expect } = require("chai");
const { ethers } = require("hardhat"); // Correctly import ethers from hardhat

describe("SteamPunk NFT Contract", () => {
  let SteamPunk, steamPunk, owner, addr1, addr2;

  beforeEach(async () => {
    // Deploy Contract
    SteamPunk = await ethers.getContractFactory("SteamPunk");
    [owner, addr1, addr2] = await ethers.getSigners();

    steamPunk = await SteamPunk.deploy(
      ethers.parseEther("0.01"), // Ensure ethers is correctly referenced
      7,
      'ipfs://bafybeibcjmuywlnbmixzpgrsgrjwwjopwfdv7huitvwgfzgxwnjybrqumi'
    );
    await steamPunk.waitForDeployment()
  });

  it("Should deploy with correct arguments passed to the constructor", async () => {
    expect(await steamPunk.mintPrice()).to.equal(ethers.parseEther("0.01"));
    expect(await steamPunk.maxSupply()).to.equal(7);
  });

  it("Should mint a new token", async () => {
    await steamPunk.connect(addr1).safeMint(addr1.address, { value: ethers.parseEther("0.05") });
    expect(await steamPunk.totalSupply()).to.equal(1);
    expect(await steamPunk.ownerOf(1)).to.equal(addr1.address);
  });


  it("Should fail to mint if insufficient funds are sent", async () => {
    await expect(
      steamPunk.connect(addr1).safeMint(addr1.address, { value: ethers.parseEther("0.001")})
    ).to.be.revertedWith("Insufficient funds sent for minting");
  });


  it("Should fail to mint if the max-supply is reached",async () => {
    for(let i = 0; i < 7; i++){
      await steamPunk.connect(addr1).safeMint(addr1.address, {value: ethers.parseEther("0.01")});
    }

    await expect(
      steamPunk.connect(addr1).safeMint(addr1.address, {value: ethers.parseEther("0.01")})
    ).to.be.revertedWith("You cannot mint any more");
  })


  it("Should allow owner to withdraw funds", async () => {
    await steamPunk.connect(addr1).safeMint(addr1.address,{value: ethers.parseEther("0.01")});
    const initialBalance = await ethers.provider.getBalance(owner.address);
    // console.log(`InitialBalance: ${initialBalance}`);
    await steamPunk.connect(owner).withdraw();

    const finalBalance = await ethers.provider.getBalance(owner.address);
    // console.log(`finalBalance: ${finalBalance}`);

    expect(finalBalance).to.be.gt(initialBalance);
  })
});
