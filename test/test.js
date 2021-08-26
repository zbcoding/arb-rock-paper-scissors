const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
  it("Should set number when its called", async function () {
    const newContract = await ethers.getContractFactory("Greeter");
    const newcontract = await newContract.deploy("Hello");
    await newcontract.deployed();

    expect(await newcontract.getNumber()).to.equal(0);

    const setNumberTx = await newcontract.setNumber(8);
    await setNumberTx.wait();
    expect(await newcontract.getNumber()).to.equal(8);
  });
  it("Should increment the number by 1", async function () {
    const newContract = await ethers.getContractFactory("Greeter");
    const deployedcontract = await newContract.deploy("Hi");
    await deployedcontract.deployed()
    const incNumberTx = await deployedcontract.incrementNumber();
    await incNumberTx.wait();
    expect(await deployedcontract.getNumber()).to.equal(1);
  });
});
