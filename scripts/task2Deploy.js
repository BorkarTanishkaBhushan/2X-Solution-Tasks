const main = async () => {
    const task2ContractFactory = await ethers.getContractFactory('task2');
    const task2Contract = await task2ContractFactory.deploy('NFT Sheild', 'NS');
    await task2Contract.deployed();
    const [owner, randomPerson] = await hre.ethers.getSigners();
    console.log("Contract deployed to: ", task2Contract.address)
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
