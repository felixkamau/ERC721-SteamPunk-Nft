const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const DEFAULT_MINT_PRICE = 0.001 * 1e18;
const DEFAULT_MAX_SUPPLY = 7;
const DEFAULT_BASE_URI = "ipfs://bafybeibcjmuywlnbmixzpgrsgrjwwjopwfdv7huitvwgfzgxwnjybrqumi";

module.exports = buildModule("SteamPunk", (m) => {
    // Parameters
    const mintPrice = m.getParameter("mintPrice",DEFAULT_MINT_PRICE);
    const maxSupply = m.getParameter("maxSupply", DEFAULT_MAX_SUPPLY);
    const baseURI = m.getParameter("baseURI", DEFAULT_BASE_URI);

    // Deploy the SteamPunk contract
    const steamPunk = m.contract("SteamPunk", [mintPrice, maxSupply, baseURI]);

    return { steamPunk };
});
// Deployed Addresses

// SteamPunk#SteamPunk - 0x5FbDB2315678afecb367f032d93F642f64180aa3