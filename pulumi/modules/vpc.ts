import * as aws from "@pulumi/aws";
import * as config from "../config";

// Create a new VPC
const vpcName = `${config.prefix}-vpc`;
const vpc = new aws.ec2.Vpc(vpcName, {
    cidrBlock: config.cidrBlock.vpc,
    enableDnsHostnames: true,
    enableDnsSupport: true,
    tags: {
        Name: vpcName,
    },
});

// Create an Internet Gateway for the VPC
const igwName = `${config.prefix}-igw`;
const internetGateway = new aws.ec2.InternetGateway(igwName, {
    vpcId: vpc.id,
    tags: {
        Name: igwName,
    },
});

// Create public subnets
const publicSubnetNameA = `${config.prefix}-public-subnet-a`;
const publicSubnetA = new aws.ec2.Subnet(publicSubnetNameA, {
    vpcId: vpc.id,
    cidrBlock: config.cidrBlock.publicSubnetA,
    mapPublicIpOnLaunch: true,
    availabilityZone: "us-west-2a",
    tags: {
        Name: publicSubnetNameA,
    },
});

const publicSubnetNameB = `${config.prefix}-public-subnet-b`;
const publicSubnetB = new aws.ec2.Subnet(publicSubnetNameB, {
    vpcId: vpc.id,
    cidrBlock: config.cidrBlock.publicSubnetB,
    mapPublicIpOnLaunch: true,
    availabilityZone: "us-west-2b",
    tags: {
        Name: publicSubnetNameB,
    },
});

// Create private subnets
const privateSubnetNameA = `${config.prefix}-private-subnet-a`;
const privateSubnetA = new aws.ec2.Subnet(privateSubnetNameA, {
    vpcId: vpc.id,
    cidrBlock: config.cidrBlock.privateSubnetA,
    availabilityZone: "us-west-2a",
    tags: {
        Name: privateSubnetNameA,
    },
});

const privateSubnetNameB = `${config.prefix}-private-subnet-b`;
const privateSubnetB = new aws.ec2.Subnet(privateSubnetNameB, {
    vpcId: vpc.id,
    cidrBlock: config.cidrBlock.privateSubnetB,
    availabilityZone: "us-west-2b",
    tags: {
        Name: privateSubnetNameB,
    },
});

// Create a route table for the public subnet
const publicRtName = `${config.prefix}-public-rt`;
const publicRouteTable = new aws.ec2.RouteTable(publicRtName, {
    vpcId: vpc.id,
    routes: [
        {
            cidrBlock: config.cidrBlock.anywhere,
            gatewayId: internetGateway.id,
        },
    ],
    tags: {
        Name: publicRtName,
    },
});

// Associate the public subnet with the route table
const publicRtaName = `${config.prefix}-public-rta`;
const publicRouteTableAssociation = new aws.ec2.RouteTableAssociation(publicRtaName, {
    subnetId: publicSubnetA.id,
    routeTableId: publicRouteTable.id,
});

// Export the IDs of the created resources
export const vpcId = vpc.id;
export const publicSubnetAId = publicSubnetA.id;
export const publicSubnetBId = publicSubnetB.id;
export const privateSubnetAId = privateSubnetA.id;
export const privateSubnetBId = privateSubnetB.id;
export const internetGatewayId = internetGateway.id;
export const publicRouteTableId = publicRouteTable.id;
