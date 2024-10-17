import * as aws from "@pulumi/aws";
import * as config from "../config";
import * as iam from "./iam";
import * as vpc from "./vpc";
import * as rds from "./rds";

// Create ECS Cluster
const clusterName = `${config.prefix}-ecs-cluster`;
const cluster = new aws.ecs.Cluster(clusterName, {
    name: clusterName,
});

// Create ECS Task Definition
const taskDefName = `${config.prefix}-td-micro`;
const containerName = `${config.prefix}-container-micro`;
const taskDefinition = new aws.ecs.TaskDefinition(taskDefName, {
    family: taskDefName,
    containerDefinitions: JSON.stringify([
        {
            name: containerName,
            image: "ghcr.io/johannez-demo/wordpress:latest",
            essential: true,
            memory: 512,
            cpu: 256,
            portMappings: [
                {
                    containerPort: 80,
                    hostPort: 80,
                    protocol: "tcp",
                },
            ],
            environment: [
                {
                    name: "WORDPRESS_DB_HOST",
                    value: rds.rdsEndpoint.apply(endpoint => endpoint.split(":")[0]), // Extract host from endpoint
                },
                {
                    name: "WORDPRESS_DB_NAME",
                    value: config.appName,
                },
                {
                    name: "WORDPRESS_DB_USER",
                    value: config.dbUsername,
                },
                {
                    name: "WORDPRESS_DB_PASSWORD",
                    value: config.dbPassword,
                },
                {
                    name: "WORDPRESS_DEBUG",
                    value: "1",
                },
            ],
        },
    ]),
    requiresCompatibilities: ["FARGATE"],
    networkMode: "awsvpc",
    cpu: "256",
    memory: "512",
    executionRoleArn: iam.ecsTaskExecutionRoleArn,
    taskRoleArn: iam.ecsTaskRoleArn,
});

const  ecsServiceSecurityGroupName = `${config.prefix}-ecs-service-sg`;
const ecsServiceSecurityGroup = new aws.ec2.SecurityGroup(ecsServiceSecurityGroupName, {
    vpcId: vpc.vpcId,
    description: "Allow HTTP and HTTPS traffic",
    ingress: [
        {
            protocol: "tcp",
            fromPort: 80,
            toPort: 80,
            cidrBlocks: ["0.0.0.0/0"], // Allow HTTP traffic from anywhere
        },
        {
            protocol: "tcp",
            fromPort: 443,
            toPort: 443,
            cidrBlocks: ["0.0.0.0/0"], // Allow HTTPS traffic from anywhere
        },
    ],
    egress: [
        {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0"], // Allow all outbound traffic
        },
    ],
    tags: {
        Name: ecsServiceSecurityGroupName,
    },
});

const serviceName = `${config.prefix}-ecs-service`;
const service = new aws.ecs.Service(serviceName, {
    cluster: cluster.arn,
    desiredCount: 1,
    launchType: "FARGATE",
    taskDefinition: taskDefinition.arn,
    networkConfiguration: {
        subnets: [vpc.publicSubnetAId, vpc.publicSubnetBId],
        securityGroups: [ecsServiceSecurityGroup.id],
        assignPublicIp: true,
    },
    tags: {
        Name: serviceName,
    },
});

// Export the task definition ARN
export const clusterArn = cluster.arn;
export const serviceId = service.id;
export const taskDefinitionArn = taskDefinition.arn;