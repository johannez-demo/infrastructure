import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import * as vpc from "./vpc";
import * as config from "../config";


// Create bastion security group to allow SSH access
let bastionOutput = pulumi.output("Bastion instance skipped");
if (config.enableBastion) {
    const bastionSgName = `${config.prefix}-bastion-sg`;
    const bastionSecurityGroup = new aws.ec2.SecurityGroup(bastionSgName, {
        vpcId: vpc.vpcId,
        description: "Allow SSH access to bastion host",
        ingress: [
            {
                protocol: "tcp",
                fromPort: 22,
                toPort: 22,
                cidrBlocks: ["0.0.0.0/0"], // Allow SSH from anywhere (restrict in production)
            },
        ],
        egress: [
            {
                protocol: "-1",
                fromPort: 0,
                toPort: 0,
                cidrBlocks: ["0.0.0.0/0"],
            },
        ],
    });

    // Create the bastion host in the public subnet with MySQL client installed
    const bastionName = `${config.prefix}-bastion`;
    const bastion = new aws.ec2.Instance(bastionName, {
        instanceType: "t3.micro",
        ami: "ami-079c0d2990b4033f4", // Amazon Linux 2 AMI
        vpcSecurityGroupIds: [bastionSecurityGroup.id],
        subnetId: vpc.publicSubnetAId,
        keyName: config.appName,
        userData: `#!/bin/bash
                yum update -y
                yum install -y mysql`,
        tags: {
            Name: bastionName,
        },
    });

    bastionOutput = bastion.publicIp;
}

// Export the bastion host public IP
export const bastion = bastionOutput;