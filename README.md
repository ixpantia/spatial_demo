# Pachyderm Spatial Demo with R

## Step 1 - push your image to a container registry

**If you you have your containers ready in a container registry, go to
step 2**

These instructions are for Google Container Registry, which we just
happened to use for the demo. It will vary slightly if you use other
infrastructure like AWS, Oracle Cloud or IBM Bluemix.

1.  Push your container to the `spatial_demo` directory in your
    container registry (you will need sufficient permissions to do so).

In our example it would look like this.

    docker build -t gcr.io/ixplaza/spatial_demo .
    docker push gcr.io/ixplaza/spatial_demo

## Step 2 - Get a cluster on Pachyderm Hub

1.  Go to [hub.pachyderm.com](https://hub.pachyderm.com) and create a
    cluster. If you want to run the demo for free, “Create a 4-hr
    Workspace”. You can also setup your own cluster locally (for
    instance with [microk8s](https://microk8s.com) or setup your own
    cluster the cloud.

2.  The Pachyderm Hub interface will give you the instructions under the
    `connect` option

![](img/connect_pachhub.png)

1.  Validate your connection with `pachctl version`. You should get a
    response with a version number for `pachctl` and `pachd`. If this
    works you can now do `pachctl shell` a utility that gives you
    autocomplete. For readability we will assume you are in the shell
    (otherwise just prepend the command with `pachctl` in all calls
    below).

2.  We will work in the `spatial_demo` directory and the following
    commands will assume that your are there.

## Step 3 - Put files on the cluster

1.  We are going to create the data repository to put the shapefiles in.
    We will call it `shapes`.

<!-- -->

    create repo shapes

Validate that the repo is there running `pachtl list repo`.

1.  We have found it easiest to work in a team with data in a bucket
    (GCP for this demo). Note that when we try to copy from our
    demo-data bucket Pachyderm will state the name of the
    service-account that needs permissions

<!-- -->

    put file shapes@master -r -f gs://pachyderm_demo/shapes/

You will need to give this service account `Storage Object Viewer`
permissions, and then repeat the command above.

## Step 4 - Launch a pipeline

1.  The key component of the pipeline is the container image that runs
    the code we need. For this demo we made the container public - you
    will need to setup some additional permissions in a production
    environment.

2.  Lets put the first pipeline to work

<!-- -->

    create pipeline -f pipelines/pipeline_separate.json

1.  We can see what is happening now on the Pachyderm Dashboard or on
    the command line with:

<!-- -->

    logs --pipeline=separate_shape
    inspect job <job_id>` # get `<job_id>` with `list job`.

1.  Once the `separate_shape` pipeline has finished, we will use the
    `playas.rds` file for each of the segments.

<!-- -->

    list file separate_shape@master:/shapes_segmentos

We then do a `cross` between input repositories so that we can use more
than one. Pachyderm will combine each datum in one repo with all those
in another so that we will have all beaches available for each segment
datum. We will create a new repo called `beaches` and bring the
`playas.rds` file there.

    create repo beaches
    get file separate_shape@master:/shapes_segmentos/playas/playas.rds -o playas.rds
    put file beaches@master -f playas.rds

On your file system you can now remove the file we downloaded from the
cluster

    rm playas.rds

1.  We can now start the pipeline to calculate distances

<!-- -->

    create pipeline -f pipeline_distances.json

We can check how the execution of the pipeline went by taking a look on
the dashboards or inspect the job. We get the job id with `list job` and
then `inspect job <job_id>`.

1.  And now we run the last pipeline that joins all the archives into
    one.

<!-- -->

    create pipeline -f pipeline_join.json

1.  When this is done, we can download the final file to our local
    machine. This is the output file of the pipeline that joins the
    segments.

<!-- -->

    get file join_segments@master:/segmentos_playas.rds -o final_result.rds

1.  **NOTE:** We suggest your remove any access you may have given to
    the pachyderm hub services account to any buckets you have used.

## What if something goes wrong

What if something goes wrong? Can we see is if any of the datums failed?
Yes, we can ask for a list of datums and check their status. If you do
this on a command line you can `grep` (search) through the list to
narrow it down.

    list datum <pipeline id>
