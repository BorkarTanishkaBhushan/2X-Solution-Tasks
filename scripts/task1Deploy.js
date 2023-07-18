const main = async () => {
    const task1ContractFactory = await ethers.getContractFactory('task1');
    const task1Contract = await task1ContractFactory.deploy('NFT Sheild', 'NS');
    await task1Contract.deployed();
    const [owner, randomPerson] = await hre.ethers.getSigners();
    console.log("Contract deployed to: ", task1Contract.address)
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();
