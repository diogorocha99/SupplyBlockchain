const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SupplyChain", function () {
    let supplyChain;
    let owner, producer, transporter, retailer;

    before(async function () {
        [owner, producer, transporter, retailer] = await ethers.getSigners();

        const SupplyChainFactory = await ethers.getContractFactory("SupplyChain");
        supplyChain = await SupplyChainFactory.deploy(producer.address, transporter.address, retailer.address);
        await supplyChain.waitForDeployment();  
    });

    it("Should create and update a product", async function () {
        // Gerar o ID do produto usando o hash
        const productId = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["string", "string"], ["Product1", "Origin1"]));
        
        // Adicionar produto
        await supplyChain.connect(producer).addProduct("Product1", "Origin1", "Details1");
        const product = await supplyChain.getProduct(productId);

        expect(product.name).to.equal("Product1");
        expect(product.currentLocation).to.equal("");

        // Atualizar estado e localização
        await supplyChain.connect(transporter).updateProductState(productId, 2, "Location1");
        const updatedProduct = await supplyChain.getProduct(productId);

        expect(updatedProduct.state).to.equal(2); // InTransit
        expect(updatedProduct.currentLocation).to.equal("Location1");
        expect(updatedProduct.locationHistory).to.include("Location1");

        // Verificar histórico de localizações
        const locationHistory = await supplyChain.getLocationHistory(productId);
        expect(locationHistory).to.include("Location1");
    });

    it("Should update the current location of a product", async function () {
        // Gerar o ID do produto usando o hash
        const productId = ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["string", "string"], ["Product1", "Origin1"]));
        
        await supplyChain.connect(transporter).updateCurrentLocation(productId, "NewLocation");
        const product = await supplyChain.getProduct(productId);

        expect(product.currentLocation).to.equal("NewLocation");
    });
});