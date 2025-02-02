#  Design Notes

## Rejected Alternatives

### Use of `throws(Failure)`

This seems like a more convenient approach than the `Result<_, Failure>`. When I tried this
the API itself worked but there were compiler crashes while using it in code.


### Having several `…Key` kinds.

I took this approach originally. However, being distinct types, they did not compose. Possibly
this could have worked with a common protocol. I'm not sure how this would have worked for code
completion though.

