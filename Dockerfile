#基于哪个镜像运行时。
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS base

#容器的工作路径。
WORKDIR /app

# 暴露的端口。
EXPOSE 80

# 基于哪个构建镜像SDK
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
#构建的容器的工作路径。
WORKDIR /src

# 复制到目标路径，也就是上面的src
COPY ["Docker.Test.Api.csproj", "./"]

#运行命令。还原引用。
RUN dotnet restore "./Docker.Test.Api.csproj"
#复制。
COPY . .
#复制文件的路径。
WORKDIR "/src/."

#编译后，输出的路径。
RUN dotnet build "Docker.Test.Api.csproj" -c Release -o /app
#发布版本。
FROM build AS publish
#发布到工作路径app。
RUN dotnet publish "Docker.Test.Api.csproj" -c Release -o /app

#把文件复制到要构建镜像的app路径下。
FROM base AS final
WORKDIR /app
COPY --from=publish /app .
#创建文件夹
CMD [ "MKDIR /app/out" ]
#设置环境变量
ENV RUN_USER "Default"
ENTRYPOINT ["dotnet", "Docker.Test.Api.dll"]