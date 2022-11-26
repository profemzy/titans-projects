locals {
  tag_name           = "titans"
  region             = "eu-north-1"
  pod_range_name     = "pod-ip-range"
  service_range_name = "service-ip-range"
}

# Set up the first resource for the IAM role. This ensures that the role has access to EKS
resource "aws_iam_role" "titans-eks-iam-role" {
  name               = "${local.tag_name}-eks-iam-role"
  path               = "/"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF
}

# attach these two policies to the above role ,
# the two policies allow you to properly access EC2 instances
# (where the worker nodes run) and EKS
# AmazonEKSClusterPolicy and AmazonEC2ContainerRegistryReadOnly-EKS
resource "aws_iam_role_policy_attachment" "titans-amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.titans-eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "titans-amazon-ec2-container-registry-readonly-eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.titans-eks-iam-role.name
}

# create the EKS cluster
resource "aws_eks_cluster" "titans-eks" {
  name     = "${local.tag_name}-cluster"
  role_arn = aws_iam_role.titans-eks-iam-role.arn
  vpc_config {
    subnet_ids = aws_subnet.titans-subnet.*.id
  }
  depends_on = [
    aws_iam_role.titans-eks-iam-role,
    aws_vpc.titans_network
  ]
}

# Set up an IAM role for the worker nodes
# AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy,
# EC2InstanceProfileForImageBuilderECRContainerBuilds
# AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role" "titans-worker-nodes" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "titans-amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.titans-worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "titans-amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.titans-worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "titans-ec2-instance-profile-for-imagebuilder-ecr-container-builds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.titans-worker-nodes.name
}

resource "aws_iam_role_policy_attachment" "titans-amazon-ec2-container-registry-readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.titans-worker-nodes.name
}

resource "aws_eks_node_group" "titans-worker-node-group" {
  cluster_name    = aws_eks_cluster.titans-eks.name
  node_group_name = "${local.tag_name}-workernodes"
  node_role_arn   = aws_iam_role.titans-worker-nodes.arn
  subnet_ids      = aws_subnet.titans-subnet.*.id
  instance_types  = ["t3.xlarge"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.titans-amazon-eks-worker-node-policy,
    aws_iam_role_policy_attachment.titans-amazon-eks-cni-policy,
    #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
