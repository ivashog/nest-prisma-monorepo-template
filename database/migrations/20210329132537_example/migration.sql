CREATE EXTENSION IF NOT EXISTS postgis;

-- CreateTable
CREATE TABLE "test" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "name" TEXT,
    "the_geom" geometry(Point, 4326) NOT NULL,
    "the_geom_webmercator" geometry(Point, 3857),

    PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "test.key_unique" ON "test"("key");
