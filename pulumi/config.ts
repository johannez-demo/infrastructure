import { camelCase } from "lodash";
import * as pulumi from "@pulumi/pulumi";

// Global constants
const CIDR_BLOCK_ANYWHERE = "0.0.0.0/0";

// Load pulumi's current stack configuration
const pulumiConfig = new pulumi.Config();

export const appName = pulumi.getProject();
export const stackName = pulumi.getStack();
export const prefix = `${appName}-${stackName}`;
export const prefixCamel = camelCase(prefix);

export const cidrBlock = {
    vpc: pulumiConfig.require("cidrBlock.vpc"),
    publicSubnetA: pulumiConfig.require("cidrBlock.publicSubnetA"),
    privateSubnetA: pulumiConfig.require("cidrBlock.privateSubnetA"),
    publicSubnetB: pulumiConfig.require("cidrBlock.publicSubnetB"),
    privateSubnetB: pulumiConfig.require("cidrBlock.privateSubnetB"),
    anywhere: CIDR_BLOCK_ANYWHERE,
};

export const dbUsername = pulumiConfig.requireSecret("dbUsername");
export const dbPassword = pulumiConfig.requireSecret("dbPassword");
