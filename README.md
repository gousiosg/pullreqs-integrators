## Pull Request Integrators survey data

A repository with survey data for how project owners (integrators) use pull
requests on Github. The repository corresponds to data and code used for the
following publication:

G. Gousios, A. Zaidman, M.-A. Storey, and A. van Deursen, “[Work Practices and Challenges in Pull-Based Development: The Integrator’s Perspective](http://www.gousios.gr/bibliography/GZSD15.html),” in *Proceedings of the 37th International Conference on Software Engineering*, 2015.

### Contents

The contents in this repository are organized as follows:

* `data`: Contains the CSV files with the raw answer set (`integrators.csv`),
the same answer set enriched with data from the [GHTorrent](http://ghtorrent.org)
dataset (`integrators-enriched.csv`) and coded answers for 5 open ended
questions.
* `doc`: Contains the sources to the camera ready version of our ICSE paper
* `R`: Contains R scripts to load, analyze and plot the answer data. The file
you are mainly interested in is `integrators-analysis.R`.

### Potential Uses

You are welcome to use the data as you please. Further uses not explored in our
ICSE paper are the following:

* Slice the dataset and explore answer sets per repository size, project team
size, activity and so on.
* Inform the design of tools for handling pull requests
* Ideas for further research

You can use [GHTorrent](http://ghtorrent.org) to enrich the dataset by
linking the repository names to .

### Citation information

If you find this data useful for your research, please consider citing
the work behind this dataset as follows:

```
@inproceedings{GZSD15,
  author = {Gousios, Georgios and Zaidman, Andy and Storey, Margaret-Anne and van Deursen, Arie},
  title = {Work Practices and Challenges in Pull-Based Development: The Integrator’s Perspective},
  booktitle = {Proceedings of the 37th International Conference on Software Engineering},
  series = {ICSE},
  year = {2015},
  month = may,
  volume = {1},
  pages = {358-368},
  location = {Florence, Italy},
  doi = {10.1109/ICSE.2015.55}
}
```
