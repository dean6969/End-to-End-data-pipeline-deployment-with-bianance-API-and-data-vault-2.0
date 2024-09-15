aws ssm start-session \
    --target i-0688d318533c751b3 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["8080"], "localPortNumber":["8080"]}'