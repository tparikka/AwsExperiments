using AutoFixture;
using AutoFixture.AutoMoq;

namespace UnitTest.Common;

public class UnitTestBase
{
    public IFixture AutoFixture => new Fixture()
        .Customize(new AutoMoqCustomization());
}