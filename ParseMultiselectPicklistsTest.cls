@IsTest
private class ParseMultiselectPicklistsTest {
    private static ParseMultiselectPicklists.Request buildRequest(String value) {
        ParseMultiselectPicklists.Request req = new ParseMultiselectPicklists.Request();
        req.picklistValue = value;
        return req;
    }

    @IsTest
    static void parsesMultipleValues() {
        List<ParseMultiselectPicklists.Request> requests = new List<ParseMultiselectPicklists.Request>{
            buildRequest('Red;Blue;Green')
        };

        List<ParseMultiselectPicklists.Response> responses = ParseMultiselectPicklists.parse(requests);

        Assert.areEqual(
            1,
            responses.size(),
            'Expected one Response per Request'
        );
        Assert.areEqual(
            new List<String>{ 'Red', 'Blue', 'Green' },
            responses[0].values,
            'Values should be split on semicolons, in order'
        );
    }

    @IsTest
    static void parsesSingleValue() {
        List<ParseMultiselectPicklists.Response> responses = ParseMultiselectPicklists.parse(
            new List<ParseMultiselectPicklists.Request>{ buildRequest('Red') }
        );

        Assert.areEqual(
            new List<String>{ 'Red' },
            responses[0].values,
            'A single value should return without issue'
        );
    }

    @IsTest
    static void returnsEmptyListForNullOrBlank() {
        List<ParseMultiselectPicklists.Request> requests = new List<ParseMultiselectPicklists.Request>{
            buildRequest(null),
            buildRequest(''),
            buildRequest('   '),
            null
        };

        List<ParseMultiselectPicklists.Response> responses = ParseMultiselectPicklists.parse(requests);

        Assert.areEqual(
            requests.size(),
            responses.size(),
            'Every Request still gets a Response, even if null'
        );
        for (ParseMultiselectPicklists.Response res : responses) {
            Assert.isNotNull(
                res.values,
                'Should be an empty list, never null'
            );
            Assert.isTrue(
                res.values.isEmpty(),
                'Blank input should yield no values'
            );
        }
    }

    @IsTest
    static void keepsResponsesAlignedWithRequests() {
        List<ParseMultiselectPicklists.Request> requests = new List<ParseMultiselectPicklists.Request>{
            buildRequest('A;B'),
            buildRequest(null),
            buildRequest('C;D;E')
        };

        List<ParseMultiselectPicklists.Response> responses = ParseMultiselectPicklists.parse(requests);

        Assert.areEqual(
            requests.size(),
            responses.size(),
            'The List of outputs should be the same size as the List of inputs'
        );
        Assert.areEqual(
            new List<String>{ 'A', 'B' },
            responses[0].values,
            'An input of \'A;B\' should be split into a List of \'A\' and \'B\''
        );
        Assert.areEqual(
            0,
            responses[1].values.size(),
            'An empty input should return an empty list'
        );
        Assert.areEqual(
            new List<String>{ 'C', 'D', 'E' },
            responses[2].values,
            'An input of \'C;D;E\' should be split into a List of \'C\', \'D\', and \'E\''
        );
    }

    @IsTest
    static void handlesBulkVolume() {
        List<ParseMultiselectPicklists.Request> requests = new List<ParseMultiselectPicklists.Request>();
        for (Integer i = 0; i < 200; i++) {
            requests.add(buildRequest('X' + i + ';Y' + i));
        }

        List<ParseMultiselectPicklists.Response> responses = ParseMultiselectPicklists.parse(requests);

        Assert.areEqual(
            200,
            responses.size(),
            'It should handle 200 items in a list'
        );
        Assert.areEqual(
            new List<String>{ 'X199', 'Y199' },
            responses[199].values,
            'The items in a List should be returned in order'
        );
    }

    @IsTest
    static void handlesMalformedInput() {
        Assert.areEqual(
            new List<String>{ 'A', 'B' },
            ParseMultiselectPicklists.splitValue('A;B;'),
            'Trailing delimiter is dropped by split()'
        );
        Assert.areEqual(
            new List<String>{ '', 'A' },
            ParseMultiselectPicklists.splitValue(';A'),
            'Leading delimiter yields an empty first element'
        );
    }
}