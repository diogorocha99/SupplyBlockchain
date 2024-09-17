async function main() {
    const [deployer, producer, transporter, retailer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const SupplyChain = await ethers.getContractFactory("SupplyChain");
    const supplyChain = await SupplyChain.deploy(producer.address, transporter.address, retailer.address);

    console.log("Waiting for deployment confirmation...");
    await supplyChain.waitForDeployment();  // Isso deve funcionar se o contrato for implantado corretamente

    console.log("SupplyChain deployed to:", supplyChain.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
