import * as aws from "@pulumi/aws";

// Create the ECS task execution IAM role
const ecsTaskExecutionRole = new aws.iam.Role("ecsTaskExecutionRole", {
    assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({ Service: "ecs-tasks.amazonaws.com" }),
});

// Attach the AmazonECSTaskExecutionRolePolicy managed policy to the role
new aws.iam.RolePolicyAttachment("ecsTaskExecutionRolePolicyAttachment", {
    role: ecsTaskExecutionRole.name,
    policyArn: "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
});

// Create the ECS task IAM role
const ecsTaskRole = new aws.iam.Role("ecsTaskRole", {
    assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({ Service: "ecs-tasks.amazonaws.com" }),
});

const cloudWatchLogsPolicy = new aws.iam.RolePolicy("ecsTaskRoleCloudWatchLogsPolicy", {
    role: ecsTaskRole.id,
    policy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [
            {
                Effect: "Allow",
                Action: [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource: "arn:aws:logs:us-west-2:123456789012:log-group:/ecs/your-log-group:*"
            }
        ]
    }),
});

export const ecsTaskExecutionRoleArn = ecsTaskExecutionRole.arn;
export const ecsTaskRoleArn = ecsTaskRole.arn;