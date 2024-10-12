import * as vpc from "./modules/vpc";
import * as rds from "./modules/rds";
import * as ec2 from "./modules/ec2";


// Create networking
export const vpcId = vpc.vpcId;
export const publicSubnetAId = vpc.publicSubnetAId;
export const publicSubnetBId = vpc.publicSubnetBId;
export const privateSubnetAId = vpc.privateSubnetAId;
export const privateSubnetBId = vpc.privateSubnetBId;
export const internetGatewayId = vpc.internetGatewayId;
export const publicRouteTableId = vpc.publicRouteTableId;

// Create RDS instance
export const rdsEndpoint = rds.rdsEndpoint;

// Create bastion host if enabled
export const bastion = ec2.bastion;
