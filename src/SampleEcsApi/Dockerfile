# syntax=docker/dockerfile:1.10

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SampleEcsApi.csproj", "src/SampleEcsApi/"]
RUN dotnet restore "src/SampleEcsApi/SampleEcsApi.csproj"
WORKDIR "src/SampleEcsApi"
COPY . .
RUN dotnet build "SampleEcsApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "SampleEcsApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=true --self-contained --runtime linux-arm64

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleEcsApi.dll"]
