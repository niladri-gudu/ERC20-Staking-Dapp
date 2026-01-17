import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("StakingContractModule", (m) => {
  const stakingToken = m.getParameter("stakingToken");
  const rewardToken = m.getParameter("rewardToken");

  const stakingContract = m.contract("StakingContract", [stakingToken, rewardToken]);

  return { stakingContract };
});
