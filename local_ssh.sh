aws ssm start-session \
    --target i-0ff0a4d6388848d67 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["8080"], "localPortNumber":["8080"]}'