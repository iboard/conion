# CentralScrutinizer


CentralScrutinizer is a package for general Elixir modules 

- A key/value store (`CentralScrutinizer.Store`) that handles `CentralScrutinizer.Store.Bucket`s
  - The `CentralScrutinizer.Store.Persistor` is a `Behaviour` that implements `read!` and `write!`
- Buckets are supervised
- A central `CentralScrutinizer.Common.Configuration` module to deal with compile and runtime
  configuration.
- A central `CentralScrutinizer.Common.CentralLogger` module to do logging in a common manner.


...more to come


## XREF

to create an xref-graph use the following command:

    mix xref graph --format dot  && \
    dot -Tpng xref_graph.dot -o xref_graph.png && \
    open xref_graph.png && \
    sleep 5 && rm xref_graph.*

