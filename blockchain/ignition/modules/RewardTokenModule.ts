import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("RewardToken", (m) => {
  const token = m.contract("RewardToken");
  return { token };
});
