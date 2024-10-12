import * as aws from "@pulumi/aws";
import * as vpc from "./vpc";
import * as config from "../config";

// Create a security group for the RDS instance
const rdsSgName = `${config.infraPrefix}-db-sg`;
const rdsSecurityGroup = new aws.ec2.SecurityGroup(rdsSgName, {
    vpcId: vpc.vpcId,
    ingress: [
        {
            protocol: "tcp",
            fromPort: 3306, // MySQL port
            toPort: 3306,
            cidrBlocks: [config.cidrBlock.publicSubnetA],
        },
    ],
    egress: [
        {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: [config.cidrBlock.anywhere],
        },
    ],
    tags: {
        Name: rdsSgName,
    },
});

// Create an RDS instance in the private subnet
const rdsName = `${config.infraPrefix}-db`;
const rdsSubGroupName = `${config.infraPrefix}-db-subnet-group`;
const rdsInstance = new aws.rds.Instance(rdsName, {
    engine: "mysql",
    instanceClass: "db.t3.micro",
    allocatedStorage: 20,
    dbSubnetGroupName: new aws.rds.SubnetGroup(rdsSubGroupName, {
        subnetIds: [
            vpc.privateSubnetAId,
            vpc.privateSubnetBId,
        ],
        tags: {
            Name: rdsSubGroupName,
        },
    }).name,
    vpcSecurityGroupIds: [rdsSecurityGroup.id],
    dbName: `${config.infraPrefixCamel}Db`,
    username: "admin",
    password: "password",
    skipFinalSnapshot: true,
    tags: {
        Name: rdsName,
    },
});

export const rdsEndpoint = rdsInstance.endpoint;