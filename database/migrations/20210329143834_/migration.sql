CREATE EXTENSION IF NOT EXISTS postgis;

-- CreateTable
CREATE TABLE "model" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "name" TEXT,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "geo_model" (
    "model_id" INTEGER NOT NULL,
    "the_geom" geometry(Point, 4326) NOT NULL,
    "the_geom_webmercator" geometry(Point, 3857)
);

-- CreateIndex
CREATE UNIQUE INDEX "model.key_unique" ON "model"("key");

-- CreateIndex
CREATE UNIQUE INDEX "geo_model.model_id_unique" ON "geo_model"("model_id");

-- AddForeignKey
ALTER TABLE "geo_model" ADD FOREIGN KEY ("model_id") REFERENCES "model"("id") ON DELETE CASCADE ON UPDATE CASCADE;
