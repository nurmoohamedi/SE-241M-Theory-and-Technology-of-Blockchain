// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const HelloWorldModule = buildModule("HelloWorldModule", (m) => {
  const helloWorld = m.contract("HelloWorld");

  const message = m.staticCall(helloWorld, "getMessage")

  console.log("Contract message", message)

  return { helloWorld };
});

export default HelloWorldModule;
