const main = async () => {
    const task3ContractFactory = await ethers.getContractFactory('task3');
    const task3Contract = await task3ContractFactory.deploy('NFT Sheild', 'NS');
    await task3Contract.deployed();
    const [owner, randomPerson] = await hre.ethers.getSigners();
    console.log("Contract deployed to: ", task3Contract.address)
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