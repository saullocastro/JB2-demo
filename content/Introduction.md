---
abstract: |
    In this demo, we demonstrate how Jupyter Book can be used to create and publish a content rich paper that includes 
    interactive elements such as code cells, visualizations, and multimedia. We will walk through the process of setting 
    up a Jupyter Book, adding content, and deploying the final product online.
---

# Introduction

Jupyter Book has been rebuild from ground up using the MyST engine [@Jupyter2025]. This allows to export content in multiple output formats including HTML, PDF and docx. In this paper we present an overview of the possibilities and demonstrate its working.

## Background
Some background information about Jupyter Book and its features, like exporting to multiple formats as indicated in {numref}`fig-diagram`.

:::{figure} ../figures/diagram.png
:label: fig-diagram
:alt: Some figure

Some figure
:::

::::{.web-only}
## Web-only content
:::{figure} ../figures/delft.*
:label: fig-delft
:alt: picture of the TUD

A figure that is in the website but none of the PDFs.
:::
::::

## Content that should appear everywhere

This text should appear in all formats.

![This picture should appear in all formats](../figures/tudelft.png)

::::{.beamer-only}
## Beamer-specific Content

```{=latex}
\begin{figure}
\centering
\only<1>{\includegraphics[width=0.5\textwidth]{figures/tudelft-dark.png}}
\caption{This picture should appear only in beamer}
\end{figure}
```
::::

A paragraph that should appear in all the website, PDF and beamer presentation.

::::{.web-only}
Another paragraph that should appear only on the website.
::::

::::{.beamer-only}
Another paragraph that should appear only in the beamer presentation.
::::

::::{.pdf-only}
Another paragraph that should appear only in the PDF.
::::

![This is a picture that should appear in all the website, PDF and beamer presentation.](../figures/diagram.png)

::::{.beamer-only}
## Final Beamer Elements
```{=latex}
\begin{figure}
\centering
\only<1>{\includegraphics[width=0.5\textwidth]{figures/delft.png}}
\caption{This is a picture that would appear only in the beamer presentation.}
\end{figure}
```
::::

::::{.pdf-only}
Another paragraph that should appear only in the PDF.
![This is a picture that should appear only in the PDF.](../figures/delft.png)
::::

