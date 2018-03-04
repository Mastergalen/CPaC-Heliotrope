# Heliotrope

UCL Computational Photography and Capture - Heliotrope Lab

## Folder structure

* Place optical flow data in `data/{dataset_name}_flows.mat`
  * For example `data/gabe_flows.mat` or `data/trump_flows.mat`
  * You can download the Trump optical flow data from [Dropbox](https://www.dropbox.com/s/anazgxynkzi8ug3/trump_flows.mat?dl=0) (1.83 GB)
* Image sequence should be in the folder `data/{dataset_name}`
  * E.g. `data/gabe/` or `data/trump/`

## Usage
* Run `heliotrope`
  * Edit the variable `dataset` in `heliotrope.m` if you wish to change the dataset
* Enter your desired starting image, or use the default recommended one by just pressing `Enter`
* Draw as many line segments as you want
* Backspace to delete previous point
* Double-click your final point to end selection
* Wait a minute...

TIP: Use the tip of the nose as starting point to deliver best results.

## Output
3 video figures will appear:

* Slow motion interpolation of trajectory-based cost
* No interpolation - Without trajectory cost
* No interpolation - With trajectory cost

## Adjustable parameters

* Inside `src/best_path.m` you can edit `alpha` to modify the weighting of the trajectory cost.