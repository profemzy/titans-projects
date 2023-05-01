## creates the EKS cluster
#resource "aws_eks_cluster" "titans-eks" {
#  name     = "${local.tag_name}-cluster"
#  role_arn = aws_iam_role.titans-eks-iam-role.arn
#  vpc_config {
#    subnet_ids = aws_subnet.titans-subnet.*.id
#  }
#  depends_on = [
#    aws_iam_role.titans-eks-iam-role,
#    aws_vpc.titans_network
#  ]
#}
#
## creates the EKS cluster node group
#resource "aws_eks_node_group" "titans-worker-node-group" {
#  cluster_name    = aws_eks_cluster.titans-eks.name
#  node_group_name = "${local.tag_name}-workernodes"
#  node_role_arn   = aws_iam_role.titans-worker-nodes.arn
#  subnet_ids      = aws_subnet.titans-subnet.*.id
#  instance_types  = ["t3.medium"]
#
#  scaling_config {
#    desired_size = 1
#    max_size     = 2
#    min_size     = 1
#  }
#
#  depends_on = [
#    aws_iam_role_policy_attachment.titans-amazon-eks-worker-node-policy,
#    aws_iam_role_policy_attachment.titans-amazon-eks-cni-policy,
#    #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#  ]
#}
