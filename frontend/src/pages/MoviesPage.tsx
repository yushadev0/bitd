import LibraryPage from "../components/LibraryPage";

export default function MoviesPage() {
  return (
    <LibraryPage
      category="movies"
      title="Filmlerim"
      completedLabel="İzlenenler"
      wishlistLabel="İzleme Listesi"
    />
  );
}
