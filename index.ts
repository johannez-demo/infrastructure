import * as vpc from "./modules/vpc";
import * as rds from "./modules/rds";

export const vpcId = vpc.vpcId;
export const publicSubnetAId = vpc.publicSubnetAId;
export const publicSubnetBId = vpc.publicSubnetBId;
export const privateSubnetAId = vpc.privateSubnetAId;
export const privateSubnetBId = vpc.privateSubnetBId;
export const internetGatewayId = vpc.internetGatewayId;
export const publicRouteTableId = vpc.publicRouteTableId;

export const rdsEndpoint = rds.rdsEndpoint;
