import { camelCase } from "lodash";
import * as pulumi from "@pulumi/pulumi";

const pulumiConfig = new pulumi.Config();

export const appName = pulumiConfig.require("appName");
export const stackName = pulumi.getStack();
export const infraPrefix = `${appName}-${stackName}`;
export const infraPrefixCamel = camelCase(infraPrefix);

export const cidrBlock = {
    vpc: "10.0.0.0/16",
    publicSubnetA: "10.0.1.0/24",
    privateSubnetA: "10.0.2.0/24",
    publicSubnetB: "10.0.3.0/24",
    privateSubnetB: "10.0.4.0/24",
    anywhere: "0.0.0.0/0",
}
