using Xunit;
using AutoFixture;
using FluentAssertions;
using UnitTest.Common;

namespace SampleApiLambda.UnitTests;

public class WeatherForecastTests : UnitTestBase
{
    [Fact]
    public void TemperatureF_Given10C_Returns50F()
    {
        // arrange
        var forecast = AutoFixture.Build<WeatherForecast>()
            .With(x => x.TemperatureC, 10)
            .With(x => x.Date, DateOnly.FromDateTime(DateTime.Now))
            .Create();
        
        // act
        var result = forecast.TemperatureF;

        // assert
        result.Should().BeCloseTo(50, 1);
    }
}